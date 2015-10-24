require 'spec_helper'

describe SetlistFm::SearchResponse::Event do
  describe '#artist' do
    subject { described_class.new(response_with_artist_info) }
    let(:response_with_artist_info) do
      {
        'artist' => {
          '@disambiguation' => '',
          '@mbid' => 'a96ac800-bfcb-412a-8a63-0a98df600700',
          '@name' => 'Modest Mouse',
          '@sortName' => 'Modest Mouse',
          '@tmid' => '781346',
          'url' => 'http://www.setlist.fm/setlists/modest-mouse-73d6ae69.html'
        }
      }
    end

    it "should return the artist's name" do
      expect(subject.artist.name).to eq 'Modest Mouse'
    end
  end

  describe '#date' do
    subject { described_class.new(response_with_date) }
    let(:response_with_date) do
      {
        '@eventDate' => '22-10-2015'
      }
    end

    it 'should return a Date object containing the date' do
      expect(subject.date).to eq Date.new(2015, 10, 22)
    end
  end

  describe '#setlist' do
    subject { described_class.new({}) }
    let(:set_list_parser) do
      double(
        'set_list_parser',
        json_songs_array: [
          { '@name' => 'song1' },
          { '@name' => 'song2', 'info' => 'Meowed intro' },
          {
            '@name' => 'encore 1 song 1',
            'info' => 'walked off stage again after'
          },
          { '@name' => 'encore 2 song 1' },
          { '@name' => 'encore 2 song 2' }
        ]
      )
    end

    before do
      allow(SetlistFm::SearchResponse::SetListParser)
        .to receive(:new)
        .and_return(set_list_parser)
    end

    it 'should have the title of each song in order' do
      expect(subject.setlist.map(&:title)).to eq([
        'song1',
        'song2',
        'encore 1 song 1',
        'encore 2 song 1',
        'encore 2 song 2'
      ])
    end
  end

  describe '#venue' do
    subject { described_class.new(response_with_venue) }
    let(:response_with_venue) do
      {
        'venue' => {
          '@id' => '53d483fd',
          '@name' => 'The Space at Westbury',
          'city' => {
            '@id' => '5144040',
            '@name' => 'Westbury',
            '@state' => 'New York',
            '@stateCode' => 'NY',
            'coords' => {
              '@lat' => '40.7556561',
              '@long' => '-73.5876273'
            },
            'country' => {
              '@code' => 'US',
              '@name' => 'United States'
            }
          }
        }
      }
    end

    it 'should have a name' do
      expect(subject.venue.name).to eq 'The Space at Westbury'
    end

    it 'should have a city' do
      expect(subject.venue.city).to eq 'Westbury'
    end

    it 'should have a state' do
      expect(subject.venue.state).to eq 'New York'
    end
  end

  describe '#url' do
    subject { described_class.new(setlist_with_url) }
    let(:setlist_with_url) do
      { 'url' => 'http://www.setlist.fm/events/1' }
    end

    it 'shold have a link to the setlist.fm page' do
      expect(subject.url).to eq 'http://www.setlist.fm/events/1'
    end
  end
end
