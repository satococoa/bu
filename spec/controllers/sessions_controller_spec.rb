# coding: utf-8
require 'spec_helper'

describe SessionsController do

  describe '#callback' do
    let(:you) { FactoryGirl.attributes_for(:user) }
    let(:auth) do
      {
        'provider' => you[:provider],
        'uid' => you[:uid],
        'info' => {'nickname' => you[:name], 'image' => you[:image]}
      }
    end

    before do
      request.env['omniauth.auth'] = auth
    end

    context 'set redirect path' do
      let(:redirect_path) { root_path }
      before do
        request.session[:redirect_path] = redirect_path
        get :callback, provider: :twitter
      end
      it { should redirect_to(redirect_path) }
    end

    context 'not exists' do
      before do
        User.should_receive(:create_with_omniauth).with(auth) do
          User.create(provider: you[:provider], uid: you[:uid])
        end
        get :callback, provider: :twitter
      end

      it { should redirect_to(my_url) }
    end

    context 'exists' do
      let(:you) { FactoryGirl.create(:user) }
      let(:auth) do
        {
          'provider' => you.provider,
          'uid' => you.uid,
          'info' => {'nickname' => you.name, 'image' => you.image}
        }
      end

      before do
        User.should_not_receive(:create_with_omniauth)
        get :callback, provider: :twitter
      end

      it { should redirect_to(my_url) }
    end
  end

  describe '#destroy' do
    let(:you) { FactoryGirl.create(:user) }

    before do
      request.session[:user_id] = you.id
      get :destroy
    end

    it { should redirect_to(root_path) }
    it { request.session[:user_id].should be_nil }
  end

end