require 'rails_helper'

RSpec.describe 'Todos API', type: :request do
  # let! is created no matter what, let is created when referenced
  # let! and let create data once, then data is available throughout tests
  let!(:todos) { create_list(:todo, 10) }  # create_list is a FactoryGirl method, it creates todo 10 times
  let(:todo_id) { todos.first.id }

  describe 'GET /todos' do
    before { get '/todos' }
    it 'returns todos' do
      expect(json).not_to be_empty  #  #json will be helper method to parse JSON responses
      expect(json.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /todos/:id' do
    before { get "/todos/#{todo_id}" }
    context 'when the record exists' do
      it 'returns the todo' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(todo_id)
      end
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end
    context 'when the record does not exist' do
      let(:todo_id) { 100 }
      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Todo/)
      end
    end
  end

  describe 'POST /todos' do
    let(:valid_attributes) { { title: 'Wash the car', created_by: '1' } }
    context 'when the request is valid' do
      before { post '/todos', params: valid_attributes }
      it 'creates a todo' do
        expect(json['title']).to eq('Wash the car')
      end

      it 'returns a status code 201' do
        expect(response).to have_http_status(201)
      end
    end
    context 'when request is not valid' do
      before { post '/todos', params: {title: 'bad post'} }
      it 'returns a status code 422' do
        expect(response).to have_http_status(422)
      end
      it 'returns a validation failure message' do
        expect(response.body).to match(/Validation failed: Created by can't be blank/)
      end
    end
  end

  describe 'PUT /todos/:id' do
    let(:valid_attributes) { { title: 'Shop' } }
    context 'when the record exists' do
      before { put "/todos/#{todo_id}", params: valid_attributes }
      it 'updates the record' do
        expect(json['title']).to eq('Shop')
      end
      it 'returns a status code 204' do
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'DELETE /todos/:id' do
    before { delete "/todos/#{todo_id}" }
    it 'returns the status code 204' do
      expect(response).to have_http_status(204)
    end
  end
end