# frozen_string_literal: true

class InnerFSM < Mel::SceneFSM
  state_machine :state, initial: :state_a1 do
    event :go_next do
      transition [:state_a1] => :finished
    end

    state :state_a1 do
      def display = false

      def choices = false

      def action
        go_next
      end
    end

    state :finished do
      def display = false

      def choices = false

      def action = false

      def still_running?
        false
      end
    end

    after_transition any => any do |machine|
      machine.decobox("[INNER] Switched state to #{machine.state_name}")
    end
  end
end

class OuterFSM < Mel::SceneFSM
  state_machine :state, initial: :state_a do
    event :go_next do
      transition [:state_a] => :state_b
      transition [:state_b] => :state_c
    end

    state :state_a do
      def display = false

      def choices = false

      def action
        visit_submachine InnerFSM.new
        go_next
      end
    end

    state :state_b do
      def display = false

      def choices = false

      def action = false

      def action
        visit_submachine InnerFSM.new
        go_next
      end
    end

    state :state_c do
      def display = false

      def choices
        []
      end

      def action
        visit_submachine InnerFSM.new
      end

      def still_running?
        false
      end
    end

    after_transition any => any do |machine|
      machine.decobox("[OUTER] Switched state to #{machine.state_name}")
    end
  end
end

RSpec.describe Mel::SceneFSM do
  context "InnerFSM" do
    let(:subject) { InnerFSM.new }
    it "starts still_running" do
      expect(subject.still_running?).to eq(true)
    end
    it "stops running after go_next" do
      subject.go_next
      expect(subject.still_running?).to eq(false)
    end
  end
  context "OuterFSM" do
    let(:subject) { OuterFSM.new }
    it "starts still_running" do
      expect(subject.still_running?).to eq(true)
    end
    it "stops running after processing the whole machine" do
      subject.visit_submachine subject
    end
  end
  it "has a version number" do
    expect(Mel::SCENE_FSM_VERSION).not_to be nil
  end
end
