defmodule Scalex do
  @moduledoc """
  Documentation for Scalex.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Scalex.hello
      :world

  """
  def light_switch do
    {:ok, led} = Circuits.GPIO.open(18, :output)
    {:ok, button} = Circuits.GPIO.open(17, :input)
    Circuits.GPIO.set_pull_mode(button, :pulldown)
    Circuits.GPIO.set_interrupts(button, :both)

    loop(%{output_ref: led, led_state: :off})
  end

  def loop(%{output_ref: led, led_state: led_state} = state) do
    receive do
      {:circuits_gpio, 17, _, 1} ->
        toggle_light(led_state, led)
    end

    state
    |> toggle_led_state
    |> loop
  end

  def toggle_led_state(%{led_state: :on} = state) do
    %{state | led_state: :off}
  end

  def toggle_led_state(%{led_state: :off} = state) do
    %{state | led_state: :on}
  end

  def toggle_light(:on, led) do
    Circuits.GPIO.write(led, 0)
  end

  def toggle_light(:off, led) do
    Circuits.GPIO.write(led, 1)
  end

  def read_it(pd_sck, dout) do
    data =
      0..23
      |> Enum.reduce(0, fn _, acc ->
        Circuits.GPIO.write(pd_sck, 1)
        read_data = Circuits.GPIO.read(dout)
        Circuits.GPIO.write(pd_sck, 0)

        new =
          acc
          |> Bitwise.<<<(1)
          |> Bitwise.|||(read_data)

        IO.puts("")
        IO.puts("========================")
        IO.puts("curr acc: " <> Integer.to_string(acc, 2))
        IO.puts("new bit: " <> Integer.to_string(read_data, 2))
        IO.puts("new acc: " <> Integer.to_string(new, 2))

        new
      end)

    Circuits.GPIO.write(pd_sck, 1)
    Circuits.GPIO.write(pd_sck, 0)

    data
  end
end
