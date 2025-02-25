class Preference():
    def __init__(self, preference: str, preference_type: str):
        self.preference = preference
        self.preference_type = preference_type
    def to_dict(self):
        return {
            "preference": self.preference,
            "preference_type": self.preference_type
        }