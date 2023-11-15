class CharactersController < ApplicationController
  def index
    @characters_by_film = Swapi.call
  end
end
