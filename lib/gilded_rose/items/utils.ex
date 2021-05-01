defmodule GildedRose.Items.Utils do
  @moduledoc """
  A collection of shared functions for item behaviours
  """

  @defualt_max 50
  @defualt_min 0

  @spec default_max_quality :: integer()
  def default_max_quality, do: @defualt_max

  @spec default_min_quality :: integer()
  def default_min_quality, do: @defualt_min

  @spec increment_quality(integer(), integer(), integer()) :: integer()
  def increment_quality(quality, amount \\ 1, max \\ @defualt_max),
    do: Kernel.min(quality + amount, max)

  @spec decrement_quality(integer(), integer(), integer()) :: integer()
  def decrement_quality(quality, amount \\ 1, min \\ @defualt_min),
    do: Kernel.max(quality - amount, min)
end
