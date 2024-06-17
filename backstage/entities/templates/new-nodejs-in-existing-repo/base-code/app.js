const express = require("express");

const app = express();

app.use((req, res, next) => {
  console.log(`Received ${req.method} request at: ${req.url}`);
  next();
});

function getRandomClassicRockBand() {
  const classicRockBands = ["Led Zeppelin", "The Rolling Stones", "Queen", "Pink Floyd", "The Who", "The Sex Pistols", "The Ramones",
    "The Beatles", "The Doors", "The Clash", "The Police", "Eagles", "AC/DC", "Aerosmith", "Black Sabbath", "Deep Purple", "Cream",
    "Def Leppard", "Dire Straits", "Fleetwood Mac", "Genesis", "Guns N' Roses", "Journey", "Kiss", "Lynyrd Skynyrd", "Metallica", 
    "Nirvana", "Pearl Jam", "R.E.M.", "Red Hot Chili Peppers", "Rush", "Deep Purple", "Scorpions", "The Cure", "The Smiths", 
    "U2", "Van Halen", "ZZ Top", "Bon Jovi", "Boston", "Cheap Trick", "Creedence Clearwater Revival", "Supertramp", "Toto", "Yes", 
    "ZZ Top", "Alice Cooper", "David Bowie", "Elton John", "Grateful Dead", "Jimi Hendrix", "King Crimson", "The Velvet Underground" 
  ];
  const randomIndex = Math.floor(Math.random() * classicRockBands.length);
  return classicRockBands[randomIndex];
}

app.get("/", async (req, res) => {
  try {
    const rockBand = getRandomClassicRockBand();
    res.json({ response: rockBand });
  } catch (error) {
    res.status(500).json({ error: "Failed to retrieve visitor count" });
  }
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
