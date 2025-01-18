/**
 * Created by baltamimi on 2022-03-09.
 */

public without sharing class Stack {
    private List<Object> items { get; set; }

    public Stack() {
        this.items = new List<Object>();
    }

    public Integer size() {
        return this.items.size();
    }

    public Boolean isEmpty() {
        return size() == 0;
    }

    public void empty() {
        while (items.size() > 0) {
            pop();
        }
    }

    public void push(Object itemToPush) {
        this.items.add(itemToPush);
    }

    public Object pop() {
        if (isEmpty()) {
            throw new StackUnderflowException();
        }

        return this.items.remove(size() - 1);
    }

    public Object peek() {
        if (isEmpty()) {
            throw new StackUnderflowException();
        }

        return this.items.get(size() - 1);
    }

    public override String toString() {
        return JSON.serialize(items);
    }

    public class StackUnderflowException extends Exception {
    }
}