// Those classes as representation of base object inside native realm
class RLMObject extends RLMObjectBase {
  fromJson(Map json) {}
  Map toJson() {
    return Map();
  }
}

class RLMObjectBase {}
