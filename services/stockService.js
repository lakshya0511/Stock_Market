import axios from "axios";

export const fetchStockPrice = async (symbol) => {
  try {
    console.log(`Fetching price for ${symbol}...`);

    const res = await axios.get(
      "https://finnhub.io/api/v1/quote",
      {
        params: {
          symbol: symbol,
          token: process.env.FINNHUB_API_KEY
        }
      }
    );

    console.log(`Response for ${symbol}:`, res.data);

    return res.data;

  } catch (err) {
    console.error(`Error fetching ${symbol}:`, err.message);
    return null;
  }
};