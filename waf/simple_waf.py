# simple_waf.py (Flask를 이용한 프록시/테스트용 보안 필터 예)
from flask import Flask, request, abort, jsonify
import re
import requests

app = Flask(__name__)
BAN_PATTERNS = [
    r"(\bor\b).*?=|'.*--",          # very naive
    r"union\s+select",
    r"sleep\(",
    r"benchmark\(",
    r"information_schema",
    r"' OR '1'='1"
]

def is_malicious(s):
    if not s:
        return False
    s = s.lower()
    for p in BAN_PATTERNS:
        if re.search(p, s):
            return True
    return False

TARGET = "http://web:80"  # docker-compose에서 web 컨테이너 이름

@app.route('/', defaults={'path': ''}, methods=['GET','POST'])
@app.route('/<path:path>', methods=['GET','POST'])
def proxy(path):
    # 조심: 실제 운영에서는 더 정교한 로깅/정책 필요
    data = request.get_data(as_text=True)
    query = request.query_string.decode() if request.query_string else ''
    if is_malicious(data) or is_malicious(query):
        return "Blocked by simple WAF", 403
    # 포워딩 (간단히)
    resp = requests.request(request.method, f"{TARGET}/{path}", data=request.get_data(), headers=request.headers, params=request.args)
    return (resp.content, resp.status_code, resp.headers.items())

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
