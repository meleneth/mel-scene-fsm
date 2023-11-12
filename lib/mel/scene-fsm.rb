# frozen_string_literal: true

require "state_machines"
require "tty-prompt"

require_relative "scene-fsm/version"

module Mel
  class SceneFSM
    def prompt
      @prompt ||= TTY::Prompt.new
    end

    def spacer
      puts "|+--------------------------------------------------------+|"
    end

    def blank_space
      puts ""
    end

    def ask_prompt(choices)
      prompt.select("Choose your Path", choices, per_page: choices_per_page)
    end

    def choices_per_page
      20
    end

    # runs a machine until completion, signaled by still_running? returning false
    def visit_submachine(machine)
      while machine.still_running?
        machine.choose_destination
      end
    end

    # all states should override this method
    def choices
      []
    end

    # all states should override this method
    def display = false

    # all states should override this method
    def action = false

    def still_running?
      true
    end

    ##
    # display, choices, and action methods all change per-state
    def choose_destination
      if (some_choices = choices)
        blank_space
        spacer
        display
        spacer
        blank_space
        ask_prompt(some_choices)
      else
        action
      end
    end

    def decobox(*lines)
      max_length = lines.map(&:length).max
      puts "+-#{"-" * max_length}-+"
      lines.each do |line|
        num_spacers = max_length - line.length
        puts "| #{line}#{" " * num_spacers} |"
      end
      puts "+-#{"-" * max_length}-+"
    end

  end
end
