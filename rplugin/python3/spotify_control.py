import base64
import json
import pynvim
import requests
import urllib.request
from os.path import expanduser

home = expanduser("~")
TOKENS_FILE = home + "/.tokens.json"

@pynvim.plugin
class SpotifyControl(object):
    def __init__(self, vim):
        self.vim = vim
        self.calls = 0
        self.first_buffer = None

    @pynvim.command('SpotifyInit', range='', nargs='*', sync=True)
    def spotify_init(self, args, range):
        self.vim.command('enew')
        self.first_buffer = self.vim.current.buffer

        playlists = self.get_playlists()
        playlistNames = []
        for playlist in playlists["items"]:
            playlistNames.append(playlist["name"])
        self.first_buffer.api.set_lines(0, -1, 0, playlistNames)
        self.vim.command('set nomodifiable')

    def get_auth_string(self):
        encode_str = self.vim.eval("g:spotify_client_id") + ":" + self.vim.eval("g:spotify_client_secret")
        print("encode_str = " + encode_str)
        encode = base64.b64encode(encode_str.encode())
        return "Basic " + encode.decode()

    def codeToToken(self):
        authorization = self.get_auth_string()

        resp = requests.post( url="https://accounts.spotify.com/api/token",
                headers={"Authorization": authorization},
                data={"grant_type": "authorization_code",
                    "code": CODE,
                    "redirect_uri": self.vim.eval("g:spotify_redirect_url")})
        print(resp)
        print(resp.content)

    def get_tokens(self):
        f = open(TOKENS_FILE, "r")
        tokens = json.loads(f.read())
        f.close()
        return tokens

    def refresh_token(self):
        tokens = self.get_tokens()
        resp = requests.post(url="https://accounts.spotify.com/api/token",
                data={"grant_type": "refresh_token", "refresh_token": self.vim.eval("g:spotify_refresh_token")},
                headers={"Authorization": self.get_auth_string()})
        new_tokens_string = resp.content.decode("utf-8")
        print(resp)
        print(new_tokens_string)
        f = open(TOKENS_FILE, "w")
        f.write(new_tokens_string)
        f.close()

    def make_spotify_request(self, url, isPost, params, retry_on_fail):
        tokens = self.get_tokens()
        resp = None
        if isPost:
            resp = requests.post(url=url, headers={"Authorization": "Bearer " + tokens["access_token"]}, data=params)
        else:
            resp = requests.get(url=url, headers={"Authorization": "Bearer " + tokens["access_token"]}, data=params)
        if resp.status_code != 200 and retry_on_fail:
            self.refresh_token()
            return self.make_spotify_request(url, isPost, params, False)
        content = json.loads(resp.content)
        return content


    def get_my_info(self):
        tokens = self.get_tokens()
        resp = self.make_spotify_request("https://api.spotify.com/v1/me", False, {}, True)
        print(resp)

    def get_playlists(self):
        tokens = self.get_tokens()
        resp = self.make_spotify_request("https://api.spotify.com/v1/me/playlists", False, {}, True)
        return resp

