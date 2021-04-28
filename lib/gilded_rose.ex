defmodule GildedRose do
  use Agent
  alias GildedRose.Item

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
        |> preliminary_quality_adjustment()
        |> adjust_sell_in()
        |> post_aging_quality_adjustment()

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

  defp preliminary_quality_adjustment(item = %Item{name: "Sulfuras, Hand of Ragnaros"}), do: item

  # if there is room to increase quality do it
  defp preliminary_quality_adjustment(item = %Item{name: "Aged Brie", quality: quality})
       when quality < 50,
       do: %Item{item | quality: quality + 1}

  # quality cannot be improved so return the item
  defp preliminary_quality_adjustment(item = %Item{name: "Aged Brie"}), do: item

  defp preliminary_quality_adjustment(
         item = %Item{name: "Backstage passes" <> _, quality: quality}
       )
       when quality < 50 do
    cond do
      item.sell_in < 6 ->
        %Item{item | quality: quality + 3}

      item.sell_in < 11 ->
        %Item{item | quality: quality + 2}

      true ->
        %Item{item | quality: quality + 1}
    end
  end

  defp preliminary_quality_adjustment(item = %Item{name: "Backstage passes" <> _}), do: item

  defp preliminary_quality_adjustment(item = %Item{quality: quality}) when quality > 0,
    do: %Item{item | quality: quality - 1}

  defp preliminary_quality_adjustment(item = %Item{}), do: item

  defp adjust_sell_in(item = %Item{name: "Sulfuras, Hand of Ragnaros"}), do: item
  defp adjust_sell_in(item = %Item{}), do: %Item{item | sell_in: item.sell_in - 1}

  defp post_aging_quality_adjustment(item = %Item{sell_in: sell_in}) when sell_in >= 0, do: item

  defp post_aging_quality_adjustment(item = %Item{name: "Backstage passes" <> _}),
    do: %Item{item | quality: 0}

  defp post_aging_quality_adjustment(item = %Item{name: "Aged Brie"}), do: item
  defp post_aging_quality_adjustment(item = %Item{name: "Sulfuras, Hand of Ragnaros"}), do: item

  defp post_aging_quality_adjustment(item = %Item{quality: quality}) when quality > 0,
    do: %Item{item | quality: quality - 1}

  defp post_aging_quality_adjustment(item = %Item{}), do: item
end
