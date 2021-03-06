module Books.Update exposing (update)

import Navigation
import Models exposing (Model)
import Books.Messages exposing (Msg(..))
import Books.Commands


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowBooks ->
            ( model, Cmd.batch [ Books.Commands.fetchBooks, Navigation.newUrl "#books" ] )

        ShowBook id ->
            ( model, Cmd.batch [ Books.Commands.fetchPagesByBookId id, Navigation.newUrl ("#books/" ++ toString id) ] )

        OnFetchBooks (Ok books) ->
            ( { model | books = books }, Cmd.none )

        OnFetchBooks (Err err) ->
            let
                _ =
                    Debug.log "error" err
            in
                ( model, Cmd.none )

        OnFetchPages (Ok pages) ->
            ( { model | pages = pages }, Cmd.none )

        OnFetchPages (Err err) ->
            let
                _ =
                    Debug.log "error" err
            in
                ( model, Cmd.none )

        CreateBook ->
            ( model, Books.Commands.postBook 1 model.newBook.title )

        OnCreateBook (Ok books) ->
            ( { model | books = books }, Cmd.none )

        OnCreateBook (Err err) ->
            let
                _ =
                    Debug.log "error" err
            in
                ( model, Cmd.none )

        NewBookTitle newTitle ->
            let
                newBook =
                    model.newBook

                updatedNewBook =
                    { newBook | title = newTitle }

                updatedModel =
                    { model | newBook = updatedNewBook }
            in
                ( updatedModel, Cmd.none )
