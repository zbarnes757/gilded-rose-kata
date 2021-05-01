defmodule GildedRose.ItemBehaviour do
  @moduledoc """
  A behaviour that can be implemented to ensure different item types expose the same functionality
  """

  alias GildedRose.Item

  @callback age_item(item :: %Item{}) :: %Item{}
  @callback adjust_quality(item :: %Item{}) :: %Item{}
end
