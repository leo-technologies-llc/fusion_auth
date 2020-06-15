defmodule FusionAuth.ResponseTest do
  use ExUnit.Case

  alias FusionAuth.Response

  @error_payload {:error, "error", %Tesla.Env{}}
  @success_payload {:ok, %{"groups" => [%{"id" => "id", "name" => "name"}]}, %Tesla.Env{}}

  describe "format/1" do
    test "when error" do
      assert {:error, "error"} = Response.format(@error_payload)
    end

    test "when success" do
      assert {:ok, %{"groups" => [%{"id" => "id", "name" => "name"}]}} =
               Response.format(@success_payload)
    end
  end

  describe "format/2" do
    test "when error" do
      assert {:error, "error"} = Response.format(@error_payload, "groups")
    end

    test "when success" do
      assert {:ok, [%{"id" => "id", "name" => "name"}]} =
               Response.format(@success_payload, "groups")
    end
  end

  describe "format/3" do
    test "when error" do
      assert {:error, "error"} =
               Response.format(@error_payload, "groups", fn record ->
                 Map.put(record, "name", "processed")
               end)
    end

    test "when success w/list" do
      assert {:ok, [%{"id" => "id", "name" => "processed"}]} =
               Response.format(@success_payload, "groups", fn record ->
                 Map.put(record, "name", "processed")
               end)
    end

    test "when success w/map" do
      response = {:ok, %{"group" => %{"id" => "id", "name" => "name"}}, %Tesla.Env{}}

      assert {:ok, %{"id" => "id", "name" => "processed"}} =
               Response.format(response, "group", fn record ->
                 Map.put(record, "name", "processed")
               end)
    end
  end
end
