defmodule Discuss.User do
  use Discuss.Web, :model

  @derive {Poison.Encoder, only: [:name]}

  schema "users" do
    field :email, :string
    field :name, :string
    field :provider, :string
    field :token, :string
    has_many :topics, Discuss.Topic
    has_many :comments, Discuss.Comment

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :name, :provider, :token])
    |> validate_required([:email, :name, :provider, :token])
  end

end
