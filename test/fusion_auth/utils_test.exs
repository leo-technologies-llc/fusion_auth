defmodule FusionAuth.UtilsTest do
  use ExUnit.Case

  alias FusionAuth.Utils

  describe "Build Query Parameters" do
    test "build_query_parameters/1 properly builds a query parameter string based on a keyword list" do
      assert "?limit=10&offset=5" == Utils.build_query_parameters(limit: 10, offset: 5)
    end

    test "build_query_parameters/1 returns the accumulator if the value for a key is nil" do
      assert "?limit=10" == Utils.build_query_parameters(limit: 10, offset: nil)
    end

    test "build_query_parameters/1 raises an error if a keyword list is not passed as the parameter" do
      assert_raise ArgumentError, fn -> Utils.build_query_parameters(12345) end
    end
  end
end
