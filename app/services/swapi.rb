class Swapi < ApplicationService
  include HTTParty
  base_uri 'swapi.dev/api'

  def initialize
    @options = {}
  end

  def call
    fetch_characters_and_films
  end

  private

  def fetch_characters_and_films
    characters_response = get_characters
    characters = characters_response.parsed_response['results'].filter { |char| char['mass'].to_i > 75 }

    film_urls = characters.map { |char| char['films'] }.flatten.uniq
    films = film_urls.map { |url| [url, get_resource(url).parsed_response['title']] }.to_h

    characters.each do |char|
      char['homeworld_name'] = get_resource(char['homeworld']).parsed_response['name']
    end

    characters_by_film = organize_characters_by_film(characters, films)
    characters_by_film
  end

  def get_resource(url)
    Rails.cache.fetch(url, expires_in: 12.hours) do
      self.class.get(url.gsub('https://swapi.dev/api', ''))
    end
  end

  def get_characters
    self.class.get('/people', @options)
  end

  def organize_characters_by_film(characters, films)
    characters_by_film = {}
    characters.each do |char|
      char['films'].each do |film_url|
        film_title = films[film_url]
        characters_by_film[film_title] ||= []
        characters_by_film[film_title] << char
      end
    end
    characters_by_film
  end
end
