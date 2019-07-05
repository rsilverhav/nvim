import pynvim
import json
from spotify_control.spotify import Spotify
from spotify_control.ui_handler import UIHandler

@pynvim.plugin
class SpotifyControl(object):
    def __init__(self, vim):
        self.vim = vim
        self.buffers = []
        self.results_context = None
        self.spotify = Spotify(vim)
        self.ui_handler = UIHandler(vim)

    def _get_buffer_by_name(self, name):
        for buffer in self.buffers:
            if buffer.name == name:
                return buffer
        return None

    def _get_buffer_by_number(self, number):
        for buffer in self.buffers:
            if buffer.number == number:
                return buffer
        return None

    @pynvim.command('SpotifyInit', range='', nargs='*', sync=True)
    def spotify_init(self, args, range):
        playlists_data = self.spotify.get_playlists_data()
        playlists = list(map(lambda playlist_data: { "title": playlist_data['name'], "uri": playlist_data['uri'] }, playlists_data))
        self.buffers = self.ui_handler.init_buffers(playlists)

    @pynvim.function('SpotifyOpenResult')
    def function_open_result(self, args):
        source_buf = args[0]
        target_buf = args[1]
        current_line = self.vim.eval('line(".")')
        row = self._get_buffer_by_number(source_buf).get_data_row(current_line)
        new_data = self.spotify.make_request(row['uri'])
        if new_data:
            self._get_buffer_by_number(target_buf).set_data(new_data)
            self.vim.command('set switchbuf=useopen')
            self.vim.command('sb {}'.format(target_buf))
    #@pynvim.function('SpotifyPlayResult')
    #def function_play_track(self, args):
    #    current_line = self.vim.eval('line(".")')
    #    current_index = current_line - 1
    #    if current_index >= 0 and current_index < len(self.results_data):
    #        track_id = self.results_data[current_index]['track']['id']
    #        self.spotify.play_track(track_id, self.results_context)

    @pynvim.function('SpotifyClose')
    def function_close(self, args):
        self.ui_handler.close()

    @pynvim.function('SpotifySearch')
    def function_search(self, args):
        search_query = self.ui_handler.query_input('Spotify search')
        search_results = self.spotify.search(search_query)
        self.ui_handler.set_results([json.dumps(search_results)])
