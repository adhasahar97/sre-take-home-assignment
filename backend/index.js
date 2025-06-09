const { MongoClient } = require("mongodb");
const express = require("express");
const cors = require("cors");
const app = express();
const port = 3000;
const url = process.env.MONGODB_URL;
const dbName = "DevOpsAssignment";

const client = new MongoClient(url);

const globalOrder = [];

const promBundle = require("express-prom-bundle");

const metricsMiddleware = promBundle({
  includeMethod: true, 
  includePath: true, 
  includeStatusCode: true, 
  includeUp: true,
  customLabels: {project_name: 'feedme-sre', project_type: 'test_metrics_labels'},
  promClient: {
    collectDefaultMetrics: {
    }
  }
});

app.use(metricsMiddleware)

var winston = require('winston'),
  expressWinston = require('express-winston');
app.use(expressWinston.logger({
    transports: [
      new winston.transports.Console()
    ],
    format: winston.format.combine(
      winston.format.json()
    ),
    meta: true, // optional: control whether you want to log the meta data about the request (default to true)
    msg: "HTTP {{req.method}} {{req.url}}", // optional: customize the default logging message. E.g. "{{res.statusCode}} {{req.method}} {{res.responseTime}}ms {{req.url}}"
    expressFormat: true, // Use the default Express/morgan request formatting. Enabling this will override any msg if true. Will only output colors with colorize set to true
    colorize: false, // Color the text and status code, using the Express/morgan color palette (text: gray, status: default green, 3XX cyan, 4XX yellow, 5XX red).
    ignoreRoute: function (req, res) { return false; } // optional: allows to skip some log messages based on request and/or response
  }));

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
    console.log("Get orders", orders)
    res.send(orders);
  });

  app.delete("/orders/:id", async (req, res) => {
    console.log("Delete order", req.params.id);
    await orderCollection.deleteOne({ _id: Number(req.params.id) });
    res.send("ok");
  });

  app.post("/orders", async (req, res) => {
    console.log("Create order");
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
