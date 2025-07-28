import { Server } from 'ws';

let clients = [];

export default function handler(req, res) {
  if (req.method !== 'GET') {
    res.status(405).end();
    return;
  }

  const { socket } = res;
  if (!socket.server.ws) {
    const wss = new Server({ noServer: true });
    socket.server.ws = wss;

    socket.server.on('upgrade', (req, sock, head) => {
      wss.handleUpgrade(req, sock, head, (ws) => {
        wss.emit('connection', ws, req);
      });
    });

    wss.on('connection', (ws) => {
      clients.push(ws);
      ws.on('close', () => {
        clients = clients.filter((client) => client !== ws);
      });
    });

    socket.server.clients = clients;
  }

  res.end();
}

export const config = {
  api: {
    bodyParser: false,
    externalResolver: true,
  },
};

export { clients };
