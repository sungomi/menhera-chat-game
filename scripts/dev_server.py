#!/usr/bin/env python3
import http.server
import os
import socketserver
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
WATCH_EXTS = {'.html', '.css', '.js', '.png', '.jpg', '.jpeg', '.json'}

def get_latest_mtime():
    latest = 0.0
    for dirpath, _, filenames in os.walk(ROOT):
        if '/scripts' in dirpath or '/.git' in dirpath:
            continue
        for fn in filenames:
            if Path(fn).suffix.lower() in WATCH_EXTS:
                try:
                    m = os.path.getmtime(os.path.join(dirpath, fn))
                    if m > latest:
                        latest = m
                except OSError:
                    pass
    return f'{latest:.6f}'

class DevHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def do_GET(self):
        if self.path == '/__dev_version':
            body = get_latest_mtime().encode('utf-8')
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain')
            self.send_header('Cache-Control', 'no-store')
            self.send_header('Content-Length', str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return
        super().do_GET()

    def end_headers(self):
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        super().end_headers()

    def log_message(self, format, *args):
        pass

if __name__ == '__main__':
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.ThreadingTCPServer(('', 4173), DevHandler) as httpd:
        print('Live-reload dev server running on http://localhost:4173')
        httpd.serve_forever()
