defmodule GildedRoseTest do
  use ExUnit.Case, async: true
  doctest GildedRose

  alias GildedRose.Item

  test "interface specification" do
    gilded_rose = GildedRose.new()
    [%GildedRose.Item{} | _] = GildedRose.items(gilded_rose)
    assert :ok == GildedRose.update_quality(gilded_rose)
  end

  test "sell_in and quality should decrease by 1 under normal circumstances" do
    items = [Item.new("+5 Dexterity Vest", 10, 20)]
    gilded_rose = GildedRose.new(items)
    assert :ok == GildedRose.update_quality(gilded_rose)
    assert [%GildedRose.Item{sell_in: 9, quality: 19}] = GildedRose.items(gilded_rose)
  end

  test "quality should reduce twice as fast when sell_in is less than 0" do
    items = [Item.new("+5 Dexterity Vest", 0, 20)]
    gilded_rose = GildedRose.new(items)
    assert :ok == GildedRose.update_quality(gilded_rose)
    assert [%GildedRose.Item{sell_in: -1, quality: 18}] = GildedRose.items(gilded_rose)
  end

  test "\"Aged Brie\" should increase in quality each day" do
    items = [Item.new("Aged Brie", 2, 0)]
    gilded_rose = GildedRose.new(items)
    assert :ok == GildedRose.update_quality(gilded_rose)
    assert [%GildedRose.Item{sell_in: 1, quality: 1}] = GildedRose.items(gilded_rose)
  end

  test "quality should never be below 0" do
    items = [Item.new("+5 Dexterity Vest", 0, 0)]
    gilded_rose = GildedRose.new(items)
    assert :ok == GildedRose.update_quality(gilded_rose)
    assert [%GildedRose.Item{sell_in: -1, quality: 0}] = GildedRose.items(gilded_rose)
  end

  test "quality should never be above 50" do
    items = [Item.new("Aged Brie", 2, 50)]
    gilded_rose = GildedRose.new(items)
    assert :ok == GildedRose.update_quality(gilded_rose)
    assert [%GildedRose.Item{sell_in: 1, quality: 50}] = GildedRose.items(gilded_rose)
  end

  test "\"Sulfuras\" should not change sell_in or quality" do
    items = [Item.new("Sulfuras, Hand of Ragnaros", 0, 80)]
    gilded_rose = GildedRose.new(items)
    assert :ok == GildedRose.update_quality(gilded_rose)
    assert [%GildedRose.Item{sell_in: 0, quality: 80}] = GildedRose.items(gilded_rose)
  end

  describe "\"Backstage passes\"" do
    test "should increase in quality by 1 when sell_in is greater than 10" do
      items = [Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20)]
      gilded_rose = GildedRose.new(items)
      assert :ok == GildedRose.update_quality(gilded_rose)
      assert [%GildedRose.Item{sell_in: 14, quality: 21}] = GildedRose.items(gilded_rose)
    end

    test "should increase in quality by 2 when sell_in is greater than 5 but less or equal to 10" do
      items = [Item.new("Backstage passes to a TAFKAL80ETC concert", 10, 20)]
      gilded_rose = GildedRose.new(items)
      assert :ok == GildedRose.update_quality(gilded_rose)
      assert [%GildedRose.Item{sell_in: 9, quality: 22}] = GildedRose.items(gilded_rose)
    end

    test "should increase in quality by 3 when sell_in is greater than or equal to 0 but less or equal to 5" do
      items = [Item.new("Backstage passes to a TAFKAL80ETC concert", 5, 20)]
      gilded_rose = GildedRose.new(items)
      assert :ok == GildedRose.update_quality(gilded_rose)
      assert [%GildedRose.Item{sell_in: 4, quality: 23}] = GildedRose.items(gilded_rose)
    end

    test "should have no quality when sell_in is less than 0" do
      items = [Item.new("Backstage passes to a TAFKAL80ETC concert", 0, 20)]
      gilded_rose = GildedRose.new(items)
      assert :ok == GildedRose.update_quality(gilded_rose)
      assert [%GildedRose.Item{sell_in: -1, quality: 0}] = GildedRose.items(gilded_rose)
    end
  end

  describe "\"Conjured\" items" do
    test "should have their quality decreased by 2 when not expired" do
      items = [Item.new("Conjured Mana Cake", 3, 6)]
      gilded_rose = GildedRose.new(items)
      assert :ok == GildedRose.update_quality(gilded_rose)
      assert [%GildedRose.Item{sell_in: 2, quality: 4}] = GildedRose.items(gilded_rose)
    end

    test "should have their quality decreased by 4 when not expired" do
      items = [Item.new("Conjured Mana Cake", 0, 6)]
      gilded_rose = GildedRose.new(items)
      assert :ok == GildedRose.update_quality(gilded_rose)
      assert [%GildedRose.Item{sell_in: -1, quality: 2}] = GildedRose.items(gilded_rose)
    end
  end

  test "\"Cheddar\" should not increase in quality beyond 20" do
    items = [Item.new("Cheddar", 5, 19)]
    gilded_rose = GildedRose.new(items)

    # age once
    assert :ok == GildedRose.update_quality(gilded_rose)
    assert [%GildedRose.Item{sell_in: 4, quality: 20}] = GildedRose.items(gilded_rose)

    # age once
    assert :ok == GildedRose.update_quality(gilded_rose)
    assert [%GildedRose.Item{sell_in: 3, quality: 20}] = GildedRose.items(gilded_rose)
  end

  test "should handle mistyped item names as the intended item" do
    items = [Item.new("aGEd bRIe CheESe", 2, 0)]
    gilded_rose = GildedRose.new(items)
    assert :ok == GildedRose.update_quality(gilded_rose)
    assert [%GildedRose.Item{sell_in: 1, quality: 1}] = GildedRose.items(gilded_rose)
  end
end
