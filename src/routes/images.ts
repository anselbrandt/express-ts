import express from "express";
import path from "path";

const images = express.static(path.join(__dirname, "../public"));

export default images;
