defmodule Discuss.AuthController do
  use Discuss.Web, :controller
  plug Ueberauth

  alias Discuss.User

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user_params = %{ token: auth.credentials.token,
                     email: auth.info.email,
                     name: auth.info.name,
                     provider: to_string(auth.provider) }
    changeset = User.changeset(%User{}, user_params)

    signin(conn, changeset)
  end

  def signout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: topic_path(conn, :index))
  end

  defp signin(conn, changeset) do
    case insert_or_update_user(changeset) do
      { :ok, user } ->
        conn
        |> put_flash(:info, "Welcome back, #{user.name}!")
        |> put_session(:user_id, user.id)
        |> redirect(to: topic_path(conn, :index))
      { :error, changeset } ->
        conn
        |> put_flash(:error, "Sorry but your #{errors_for(changeset)}")
        |> redirect(to: topic_path(conn, :index))
    end
  end

  defp insert_or_update_user(changeset) do
    case Repo.get_by(User, email: changeset.changes.email) do
      nil ->
        Repo.insert(changeset)
      user ->
        { :ok, user }
    end
  end

  defp errors_for(changeset) do
    Enum.map(changeset.errors, fn error ->
      { field, { errors, _ }} = error
      "#{to_string(field)}: #{errors}"
    end) |> Enum.join(", ")
  end
end
