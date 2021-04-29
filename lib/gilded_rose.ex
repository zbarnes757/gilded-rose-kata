defmodule GildedRose do
  use Agent
  alias GildedRose.Item

  @max_quality 50
  @min_quality 0

  def new(items \\ default_items()) do
    {:ok, agent} = Agent.start_link(fn -> items end)

    agent
  end

  def items(agent), do: Agent.get(agent, & &1)

  def update_quality(agent) do
    for i <- 0..(Agent.get(agent, &length/1) - 1) do
      item = Agent.get(agent, &Enum.at(&1, i))

      item =
        item
        |> age_item()
        |> do_quality_adjustment()

      Agent.update(agent, &List.replace_at(&1, i, item))
    end

    :ok
  end

  # Helpers

  defp default_items do
    [
      Item.new("+5 Dexterity Vest", 10, 20),
      Item.new("Aged Brie", 2, 0),
      Item.new("Elixir of the Mongoose", 5, 7),
      Item.new("Sulfuras, Hand of Ragnaros", 0, 80),
      Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20),
      Item.new("Conjured Mana Cake", 3, 6)
    ]
  end

  defp age_item(item = %Item{name: "Sulfuras, Hand of Ragnaros"}), do: item
  defp age_item(item = %Item{}), do: %Item{item | sell_in: item.sell_in - 1}

  defp do_quality_adjustment(item = %Item{name: "Sulfuras, Hand of Ragnaros"}), do: item

  defp do_quality_adjustment(item = %Item{name: "Aged Brie"}),
    do: %Item{item | quality: increment_quality(item.quality)}

  defp do_quality_adjustment(item = %Item{name: "Backstage passes" <> _}) do
    cond do
      item.sell_in < 0 ->
        %Item{item | quality: 0}

      item.sell_in < 6 ->
        %Item{item | quality: increment_quality(item.quality, 3)}

      item.sell_in < 11 ->
        %Item{item | quality: increment_quality(item.quality, 2)}

      true ->
        %Item{item | quality: increment_quality(item.quality)}
    end
  end

  defp do_quality_adjustment(item = %Item{name: "Conjured" <> _, sell_in: sell_in})
       when sell_in < 0,
       do: %Item{item | quality: decrement_quality(item.quality, 4)}

  defp do_quality_adjustment(item = %Item{name: "Conjured" <> _}),
    do: %Item{item | quality: decrement_quality(item.quality, 2)}

  defp do_quality_adjustment(item = %Item{sell_in: sell_in})
       when sell_in < 0,
       do: %Item{item | quality: decrement_quality(item.quality, 2)}

  defp do_quality_adjustment(item = %Item{}),
    do: %Item{item | quality: decrement_quality(item.quality)}

  defp increment_quality(quality, amount \\ 1), do: Kernel.min(quality + amount, @max_quality)
  defp decrement_quality(quality, amount \\ 1), do: Kernel.max(quality - amount, @min_quality)
end
