# Coach

### What Does Coach Do?

- When activated, Coach auto invites players that "whisper" your character when specific requirements are met.
  - Gearscore is above the minimum gearscore.
  - Spec/role specification required.
    - Generally, specifying a spec is sufficient; for example, 'Disc' will be assumed as healer. However, certain specs like Frost DK are ambiguous and require clarification since they can be either a tank or a DPS.
  - Most of the time Class is inferred from the spec/role.
    - For instance, one time where we would need clarification on the class is if the message was "Resto". Since Resto could refer to a Shaman or a Druid, we can't infer the class from just "Resto".
  - Messages players back asking for the missing pieces of information that we need. (A maximum of 1 whisper to per player.)
    - Remembers the pieces of information that we need from previous messages.
  - Looks for slightly misspelled role/classes. ([Levenshtein distance algorithm](https://en.wikipedia.org/wiki/Levenshtein_distance))
  - Intuitive GUI to update, add or remoove players from the Raid Table.
- Available Options
  - Maximum/Minimum of a certain class.
  - Maximum of a certain class/role combo. (healer shaman, ranged dps shaman, etc.)
