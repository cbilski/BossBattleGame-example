class CharacterDialog
  def self.create_dialog(dialog_id)
    case dialog_id
    when :dialog_text_1
      [
        {portrait: :player, text: "Again?! Kidnapped after a night\nout? I need better friends...\n*Ugh* My head."},
        {portrait:   :boss, text: "Good: you're awake!\nWithout coffee, you're no match\nfor me! HAHAHA!"},
        {portrait: :player, text: "CORTADO?\n(This will be rough without a\nmorning pick-me-up.)"},
        {portrait:   :boss, text: "I'm 3 cups in.\nLet's see how you like the taste of a BITTER PUNCH!"},
      ]
    when :dialog_text_2
      [
        {portrait: :boss, text: "IMPRESSIVE! Even without a\ncaffeine jump start, you've got\nskills."},
        {portrait: :boss, text: "Let's see how you like my\nBEAN ROASTERS!"},
      ]
    when :dialog_text_3
      [
        {portrait: :boss, text: "WHAT?! Those should have singed your arabica tasters!"},
        {portrait: :npc1, text: "Ho there, friend!"},
        {portrait: :boss, text: "NO!\nCUPPA'JO! How'd you...\n... Don't meddle in this!"},
        {portrait: :npc1, text: "I've got what you need, pal.\nLet me set you up with some\nFRESH BREW!"},
        {portrait: :boss, text: "BAH!\nYou're no match for foul-tasting\nARTIFICIAL SWEETENER!"},
      ]
    when :dialog_text_4
      [
        {portrait: :player, text: "Keep 'em coming, 'JO!"},
        {portrait: :boss, text: "(VISIBLE CONFUSION)"},
        {portrait: :boss, text: "..."},
        {portrait: :boss, text: "Here we go: I'm going to give you EVERYTHING now!"},
      ]
    else
      []
    end
  end
end
