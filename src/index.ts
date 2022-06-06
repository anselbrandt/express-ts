import Database from "better-sqlite3";
import bodyParser from "body-parser";
import * as dotenv from "dotenv";
import express, { Express } from "express";
import noteStore from "./model/notes";
import router from "./routes";
dotenv.config();

async function main() {
  const app: Express = express();
  const port = process.env.PORT || 5000;

  const db = new Database("./notes.db", { verbose: console.log });

  const store = noteStore(db);

  store.init();

  const r = router;

  app.use("/api/graphql", r.graphql(store));
  app.use(bodyParser.json());
  app.use("/images", r.images);
  app.use("/api/notes", r.notes(store));
  app.use("/", r.web);

  app.listen(port, () => {
    console.log(`⚡️[server]: Server is running at https://localhost:${port}`);
  });
}

main().catch((error) => console.log(error));
