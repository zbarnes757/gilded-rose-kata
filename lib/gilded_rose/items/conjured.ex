defmodule GildedRose.Items.Conjured do
  @behaviour GildedRose.ItemBehaviour

  alias GildedRose.Item
  alias GildedRose.Items.Utils

  @impl true
  def age_item(item = %Item{}) do
    %Item{item | sell_in: item.sell_in - 1}
  end

  @impl true
  def adjust_quality(item = %Item{sell_in: sell_in}) when sell_in < 0,
    do: %Item{item | quality: Utils.decrement_quality(item.quality, 4)}

  def adjust_quality(item = %Item{}),
    do: %Item{item | quality: Utils.decrement_quality(item.quality, 2)}
end
