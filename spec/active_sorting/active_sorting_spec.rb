require 'spec_helper'

describe ActiveSorting do
  let(:item) { Item.create! }
  let(:items) do
    6.times { Item.create! }
    Item.all
  end

  let(:reset) do
    Item.destroy_all
    # Reset sequence field for database table, makes comparison easier
    ActiveRecord::Base
      .connection
      .execute("DELETE FROM sqlite_sequence
                WHERE name = 'items'")
  end

  context 'ActiveRecord hooks' do
    context 'create' do
      it { expect(item.send(item.class.active_sorting_field)).not_to be_nil }
      it 'generates correct steppings' do
        items.each_with_index do |item, index|
          value = index * item.class.active_sorting_options[:step]
          expect(item.send(item.class.active_sorting_field).to_s).to eq value.to_s
        end
      end
    end

    context 'update' do
      before do
        item.save!
      end
      it 'does not change sorting field' do
        expect(item.send(item.class.active_sorting_field)).not_to be_nil
      end
    end
  end

  context '.active_sorting_center_item' do
    it 'centers an item between two given positions' do
      expect(item.active_sorting_center_item(100, 200).send(item.class.active_sorting_field)).to eq 150
      expect(item.active_sorting_center_item(100_000_000, 100_000_002).send(item.class.active_sorting_field)).to eq 100_000_001
      expect(item.active_sorting_center_item(2_000_000_000, 2_000_000_002).send(item.class.active_sorting_field)).to eq 2_000_000_001
    end
  end

  context '.active_sorting_changes_required' do
    let(:calculated) { item.class.active_sorting_changes_required(items.map(&:id), new_order) }
    before :each do
      reset
    end
    context 'calculates 1 change when' do
      context 'moving first to last' do
        let(:new_order) { [2, 3, 4, 5, 6, 1, 7] }
        it { expect(calculated).to eq [1] }
      end

      context 'moving second downward' do
        let(:new_order) { [1, 3, 4, 5, 2, 6, 7] }
        it { expect(calculated).to eq [2] }
      end

      context 'moving third downward' do
        let(:new_order) { [1, 2, 4, 5, 3, 6, 7] }
        it { expect(calculated).to eq [3] }
      end

      context 'moving fourth upward' do
        let(:new_order) { [1, 4, 2, 3, 5, 6, 7] }
        it { expect(calculated).to eq [4] }
      end

      context 'moving fifth upward' do
        let(:new_order) { [1, 5, 2, 3, 4, 6, 7] }
        it { expect(calculated).to eq [5] }
      end

      context 'moving last to first' do
        let(:new_order) { [7, 1, 2, 3, 4, 5, 6] }
        it { expect(calculated).to eq [7] }
      end

      context 'moving last upward' do
        let(:new_order) { [1, 2, 7, 3, 4, 5, 6] }
        it { expect(calculated).to eq [7] }
      end
    end
    context 'calculates 2 changes when' do
      context 'move middle items' do
        let(:new_order) { [1, 2, 6, 3, 5, 4, 7] }
        it { expect(calculated).to eq [6, 5] }
      end

      context 'move middle items' do
        let(:new_order) { [1, 5, 2, 3, 6, 4, 7] }
        it { expect(calculated).to eq [5, 6] }
      end

      context 'swap terminal items' do
        let(:new_order) { [7, 2, 3, 4, 5, 6, 1] }
        it { pending 'handling terminal swaps'; expect(calculated).to eq [1, 7] }
      end

      context 'move 3 items not including terminal items' do
        let(:new_order) { [1, 3, 5, 4, 6, 2, 7] }
        it { expect(calculated.count).to eq 2 }
      end
    end

    context 'calculates 3 changes when' do
      let(:changes) { 3 }
      context 'move 3 items including terminal items' do
        let(:new_order) { [7, 1, 3, 2, 5, 4, 6] }
        it { expect(calculated.count).to eq changes }
      end
    end
  end
end
