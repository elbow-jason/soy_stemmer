defmodule SoyStemmerTest do
  use ExUnit.Case
  doctest SoyStemmer

  describe "new/0" do
    test "defaults to en stemmer and en stopwords" do
      assert {:ok, filt} = SoyStemmer.new()
      words = ["eating", "i", "isn't", "we", "equally"]
      assert SoyStemmer.remove_stopwords_and_stem(filt, words) == ["eat", "equal"]
    end
  end

  describe "new/1" do
    test "works for en" do
      assert {:ok, _} = SoyStemmer.new("en")
    end

    test "returns an err for stopwords file that does not exist" do
      assert {:error, {:stopwords_file_does_not_exist, filepath}} = SoyStemmer.new("bleep")
      refute File.exists?(filepath)
    end
  end

  @stemmer_supported_langs [
    "en",
    "ar",
    "da",
    "du",
    "fi",
    "fr",
    "ge",
    "gr",
    "hu",
    "it",
    "no",
    "po",
    "ro",
    "ru",
    "sp",
    "sw",
    "ta",
    "tu"
  ]

  describe "new/2" do
    for lang <- @stemmer_supported_langs do
      @lang lang
      test "stemmer lang #{inspect(@lang)} is supported" do
        assert {:ok, _} = SoyStemmer.new(@lang, [])
      end
    end

    test "returns an err for stopwords file that does not exist" do
      assert {:error, reason} = SoyStemmer.new("bloop", [])
      assert reason == "stemming language not supported: bloop"
    end
  end

  describe "stem/2" do
    test "works for en" do
      assert {:ok, filt} = SoyStemmer.new("en", [])
      words = ["eating", "i", "isn't", "we", "equally"]
      assert SoyStemmer.stem(filt, words) == ["eat", "i", "isn't", "we", "equal"]
    end
  end

  describe "remove_stopwords/2" do
    test "works for en" do
      assert {:ok, filt} = SoyStemmer.new("en", ["bleep"])
      words = ["eating", "bleep", "equally"]
      assert SoyStemmer.remove_stopwords(filt, words) == ["eating", "equally"]
    end
  end

  describe "remove_stopwords_and_stem/2" do
    test "works for en" do
      assert {:ok, filt} = SoyStemmer.new("en", ["bleep"])
      words = ["eating", "bleep", "equally"]
      assert SoyStemmer.remove_stopwords_and_stem(filt, words) == ["eat", "equal"]
    end
  end
end
