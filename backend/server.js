const express = require('express');
const axios = require('axios');
const cors = require('cors');
const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

// List of 50 crypto IDs (from CoinGecko)
const cryptoIds = [
  'bitcoin', 'ethereum', 'binancecoin', 'cardano', 'solana', 'ripple', 'polkadot', 'dogecoin', 'avalanche-2', 'shiba-inu',
  'matic-network', 'chainlink', 'uniswap', 'cosmos', 'stellar', 'near', 'algorand', 'tron', 'vechain', 'hedera-hashgraph',
  'tezos', 'eos', 'theta-token', 'fantom', 'decentraland', 'the-sandbox', 'axie-infinity', 'elrond-erd-2', 'helium',
  'monero', 'pancakeswap-token', 'klay-token', 'flow', 'aave', 'maker', 'compound-governance-token', 'curve-dao-token',
  'sushi', 'yearn-finance', '1inch', 'basic-attention-token', 'enjincoin', 'zcash', 'dash', 'kusama', 'waves', 'chiliz',
  'terra-luna', 'aptos', 'arbitrum'
].join(',');

// Cache for prices
let cachedPrices = {};
let lastFetchTime = 0;
const CACHE_DURATION = 30 * 1000; // 30 seconds in milliseconds

// Fetch prices and cache them
async function fetchAndCachePrices() {
  try {
    const response = await axios.get(
      `https://api.coingecko.com/api/v3/simple/price?ids=${cryptoIds}&vs_currencies=usd`
    );
    cachedPrices = response.data;
    lastFetchTime = Date.now();
    return cachedPrices;
  } catch (error) {
    if (error.response && error.response.status === 429) {
      console.log('Rate limit hit, using cached prices');
      return cachedPrices; // Return cached prices if rate limit is hit
    }
    throw error;
  }
}

// Fetch live crypto prices
app.get('/prices', async (req, res) => {
  try {
    // Fetch new prices if cache is stale
    if (Date.now() - lastFetchTime > CACHE_DURATION || Object.keys(cachedPrices).length === 0) {
      const prices = await fetchAndCachePrices();
      res.json(prices);
    } else {
      res.json(cachedPrices);
    }
  } catch (error) {
    res.status(500).send('Error fetching prices');
  }
});

// Simulated trade execution
let balance = 10000;
let holdings = Object.fromEntries(cryptoIds.split(',').map(id => [id, 0]));

app.post('/trade', async (req, res) => {
  const { crypto, amount, action } = req.body;

  // Use cached price if available, otherwise fetch
  let price;
  if (cachedPrices[crypto] && Date.now() - lastFetchTime <= CACHE_DURATION) {
    price = cachedPrices[crypto].usd;
  } else {
    try {
      const prices = await fetchAndCachePrices();
      price = prices[crypto]?.usd;
    } catch (error) {
      return res.status(500).send('Error fetching price for trade');
    }
  }

  if (!price) {
    return res.status(400).send('Price not available');
  }

  const cost = price * amount;

  if (action === 'buy' && cost <= balance) {
    balance -= cost;
    holdings[crypto] += amount;
    res.json({ balance, holdings });
  } else if (action === 'sell' && holdings[crypto] >= amount) {
    balance += cost;
    holdings[crypto] -= amount;
    res.json({ balance, holdings });
  } else {
    res.status(400).send('Invalid trade');
  }
});

app.listen(port, () => {
  console.log(`Server running at http://127.0.0.1:${port}`);
});