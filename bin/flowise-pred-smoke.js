const flowId = process.argv[2];

if (!flowId) {
  console.error("missing flow id");
  process.exit(2);
}

const url = `http://127.0.0.1:3000/api/v1/prediction/${flowId}`;

fetch(url, {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ question: "test" }),
})
  .then(async (res) => {
    const text = await res.text();
    console.log(`status=${res.status}`);
    console.log(text.slice(0, 600));
    process.exit(res.ok ? 0 : 1);
  })
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
