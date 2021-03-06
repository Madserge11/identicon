defmodule Identicon do
  @moduledoc """
  Takes a String and generates a profile icon.
  """


  @doc """
  input is string, takes the input and pipes it down all the other fuctions from top to bottom.
  """
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  @doc """
  Saves the image as a .png file and saves it as the string you feed it at the begining.
  """
  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

  @doc """
  
  """
  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  @doc """
  Builds the square mapping for the image.
  """
  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  @doc """
  Filters odd number squares so they do not get colored in.
  """
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end

  @doc """
  Takes the list chunks it up in 3 pieces then mirrors the 1st 2(examples are in mirror row function)
  """
  def build_grid(%Identicon.Image{hex: hex} = image)do
    grid = hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end


  @doc """
  mirrors the first 2 numbers in the list but in reverse order.
  """
  def mirror_row (row) do
    # Example [199, 148, 99]
    [first, second | _tail] = row

    # Example [199, 148, 99, 148, 199]
    row ++ [second, first]
  end

  @doc """
  Takes the first three sets of numbers from the list and uses them as the RGB color
  """
  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  @doc """
  Takes the input and turns it into a list.
  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end
end
