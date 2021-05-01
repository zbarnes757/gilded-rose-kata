defmodule GildedRose.Items.BackstagePass do
  @behaviour GildedRose.ItemBehaviour

  alias GildedRose.Item
  alias GildedRose.Items.Utils

  @impl true
  def age_item(item = %Item{}) do
    %Item{item | sell_in: item.sell_in - 1}
  end

  @impl true
  def adjust_quality(item = %Item{}) do
    cond do
      item.sell_in < 0 ->
        %Item{item | quality: 0}

      item.sell_in < 6 ->
        %Item{item | quality: Utils.increment_quality(item.quality, 3)}

      item.sell_in < 11 ->
        %Item{item | quality: Utils.increment_quality(item.quality, 2)}

      true ->
        %Item{item | quality: Utils.increment_quality(item.quality)}
    end
  end
end
