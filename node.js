import express from "express";
import axios from "axios";

const app = express();

// This stores your last token
let ebayToken = null;
let tokenExpiry = 0;

async function getEbayToken() {
  // If the token is still valid, reuse it
  if (Date.now() < tokenExpiry) return ebayToken;

  const res = await axios.post(
    "https://api.ebay.com/identity/v1/oauth2/token",
    "grant_type=client_credentials&scope=https://api.ebay.com/oauth/api_scope",
    {
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      auth: {
        username: process.env.EBAY_CLIENT_ID,
        password: process.env.EBAY_CLIENT_SECRET,
      }
    
    }
  )
};