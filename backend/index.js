const { MongoClient } = require("mongodb");
const express = require("express");
const cors = require("cors");
const app = express();
const port = 3000;
const url = process.env.MONGODB_URL;
const dbName = "DevOpsAssignment";

const client = new MongoClient(url);

const globalOrder = [];

async function main() {
  // Use connect method to connect to the server
  await client.connect();
  console.log("Connected to mongodb");

  const db = client.db(dbName);
  const counterCollection = db.collection("counters");
  const orderCollection = db.collection("orders");
  await counterCollection.updateOne(
    { _id: "orderSeq" },
    { $setOnInsert: { seq: 1 } },
    { upsert: true }
  );
  console.log("Prepared mongodb");

  app.use(cors());

  app.get("/orders", async (req, res) => {
    const orders = await orderCollection.find({}).toArray();
    res.send(orders);
  });

  app.delete("/orders/:id", async (req, res) => {
    await orderCollection.deleteOne({ _id: Number(req.params.id) });
    res.send("ok");
  });

  app.post("/orders", async (req, res) => {
    const orderSeq = await counterCollection.findOne({ _id: "orderSeq" });
    await orderCollection.insertOne({
      _id: orderSeq.seq++,
    });
    await counterCollection.updateOne(
      { _id: "orderSeq" },
      { $inc: { seq: 1 } }
    );
    globalOrder.push(Buffer.alloc(1000 * 1000 * 200, 1));
    res.send("ok");
  });

  app.listen(port, () => {
    console.log(`DevOps assignment app listening at http://localhost:${port}`);
  });
}

main()
  .then(() => console.log("server started"))
  .catch((err) => console.error(err));
