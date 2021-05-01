defmodule GildedRose do
  use Agent
  alias GildedRose.Item

  alias GildedRose.Items.{
    BackstagePass,
    Cheese,
    Common,
    Conjured,
    Legendary
  }

  def new(items \\ default_items()) do
    {:ok, agent} = Agent.start_link(fn -> items end)

    agent
  end

  def items(agent), do: Agent.get(agent, & &1)

  def update_quality(agent) do
    for i <- 0..(Agent.get(agent, &length/1) - 1) do
      item = Agent.get(agent, &Enum.at(&1, i))

      module = assign_behaviour_module(item)

      item =
        item
        |> age_item(module)
        |> do_quality_adjustment(module)

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

  @behaviour_mapping [
    {~w(backstage)s, BackstagePass},
    {~w(cheese brie parmesan cheddar)s, Cheese},
    {~w(conjured)s, Conjured},
    {~w(sulfuras)s, Legendary}
  ]

  defp assign_behaviour_module(%Item{name: name}) do
    normalized_name = String.downcase(name)

    Enum.reduce_while(@behaviour_mapping, Common, fn {search_terms, module}, current_module ->
      # if the normalized name contains any of the search terms, use that module
      if Enum.any?(search_terms, &String.contains?(normalized_name, &1)) do
        {:halt, module}
      else
        {:cont, current_module}
      end
    end)
  end

  defp age_item(item, module), do: apply(module, :age_item, [item])

  defp do_quality_adjustment(item, module), do: apply(module, :adjust_quality, [item])
end
