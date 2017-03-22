require 'test_helper'

describe Prawn::Emoji::Drawer do
  let(:document) { Prawn::Document.new }
  let(:drawer) { Prawn::Emoji::Drawer.new document: document }

  let(:sushi)  { '🍣' }
  let(:sushi_image) { Prawn::Emoji::Image.new(sushi) }

  before do
    document.font Prawn::Emoji.root.join 'test', 'fonts', 'DejaVuSans.ttf'
  end

  describe '#draw' do
    subject { drawer.draw(text, {}) }

    describe 'when text encoding is not utf-8' do
      let(:text) { "\xe8\x8a\xb1".force_encoding('ascii-8bit') }

      it 'skip' do
        mock(drawer).draw_emoji(text, {}).never
        subject
      end
    end

    describe 'when text encoding is utf-8' do
      let(:text) { "\xe8\x8a\xb1" }

      it 'performs' do
        mock(drawer).draw_emoji(text, {}).once
        subject
      end
    end
  end

  describe '#draw_emoji' do
    subject { drawer.send :draw_emoji, text, text_options }
    let(:text_options) { { at: [100, 100], font_size: 12 } }

    describe 'when not includes emoji' do
      let(:text) { 'abc' }

      it 'returns original text' do
        subject.must_be_same_as text
      end
    end

    describe 'when includes emoji' do
      let(:text) { "aaa#{sushi}bbb"}

      it 'draws image for included emoji' do
        image_width = 12
        image_at    = [100 + document.width_of('aaa', text_options), 100 + 12]

        mock(drawer).draw_emoji_image(sushi_image, at: image_at, width: image_width).once
        subject
      end

      it 'returns text that all emoji has substituted' do
        subject.must_equal "aaa#{Prawn::Emoji::Substitution.new(document)}bbb"
      end
    end
  end

  describe '#draw_emoji_image' do
    subject { drawer.send :draw_emoji_image, sushi_image, at: [100, 100], width: 12 }

    it 'calls Prawn::Document#image with valid arguments' do
      mock(document).image(sushi_image.path, at: [100, 100], width: 12).once
      subject
    end
  end
end
