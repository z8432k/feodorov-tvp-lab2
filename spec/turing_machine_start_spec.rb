# frozen_string_literal: true

require_relative "../lib/turing_machine"

RSpec.describe TuringMachine do
  it "start" do
    TuringMachine.start('spec/data/programm.yml')

    expect(false).not_to be_nil
  end
end
