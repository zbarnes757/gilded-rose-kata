defmodule GildedRose.Items.Cheese do
  @behaviour GildedRose.ItemBehaviour

  alias GildedRose.Item
  alias GildedRose.Items.Utils

  @impl true
  def age_item(item = %Item{}) do
    %Item{item | sell_in: item.sell_in - 1}
  end

  @impl true
  def adjust_quality(item = %Item{}) do
    max_quality = get_max_quality(item.name)
    %Item{item | quality: Utils.increment_quality(item.quality, 1, max_quality)}
  end

  # Helpers

  @cheese_max_qualities [
    {"cheddar", 20}
  ]

  defp get_max_quality(item_name) do
    item_name = String.downcase(item_name)

    Enum.reduce_while(
      @cheese_max_qualities,
      Utils.default_max_quality(),
      fn {cheese, quality}, current_quality ->
        if String.contains?(item_name, cheese) do
          {:halt, quality}
        else
          {:cont, current_quality}
        end
      end
    )
  end
end
