// Those classes as representation of base object inside native realm
class RLMObject extends RLMObjectBase {
  RLMObject fromJson(Map json) {
    return this;
  }
  Map toJson() {
    return Map();
  }
}

class RLMObjectBase {}
