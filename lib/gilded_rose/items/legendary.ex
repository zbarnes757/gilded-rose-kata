defmodule GildedRose.Items.Legendary do
  @behaviour GildedRose.ItemBehaviour

  alias GildedRose.Item

  @impl true
  def age_item(item = %Item{}), do: item

  @impl true
  def adjust_quality(item = %Item{}), do: item
end
