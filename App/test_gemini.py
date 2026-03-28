import requests

url = "https://generativelanguage.googleapis.com/v1beta/models?key=AIzaSyAhK9X0ha_NytzVfRLTiynigffczNkJmcc"

try:
    res = requests.get(url)
    print("Status Code:", res.status_code)
    print("Response snippet:", res.text[:200])
except Exception as e:
    print("Error:", e)
