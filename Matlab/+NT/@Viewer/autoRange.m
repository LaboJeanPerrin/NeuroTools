function autoRange(this, id)

this.stacks(id).range = double([min(this.stacks(id).data(:)) max(this.stacks(id).data(:))]);
