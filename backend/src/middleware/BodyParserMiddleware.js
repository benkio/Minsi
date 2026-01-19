// Use Express's built-in JSON parser (available in Express 4.16+)
// This avoids the body-parser dependency
import express from "express";

export const jsonBodyParser = express.json();
