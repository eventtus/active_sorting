require 'spec_helper'

describe ActiveSorting do
  let(:sports) { Category.create!(name: 'Sports') }
  let(:local) { Category.create!(name: 'Local') }
  let(:page) { Page.create!(title: 'test page', category: local) }

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

  context 'options validations' do
    it { expect { Category.sortable(:position, step: 20.1) }.to raise_error(ArgumentError) }
    it { expect { Category.sortable(:position, scope: 'foo') }.to raise_error(ArgumentError) }
  end

  context 'ActiveRecord integration' do
    context 'scopes' do
      before do
        5.times { Page.create!(title: 'test sports page', category: sports) }
        10.times { Page.create!(title: 'test local page', category: local) }
      end

      it 'restarts steps based on scope' do
        expect(Page.where(category: local).to_a.second.active_sorting_value).to eq 2 * Page.active_sorting_step
        expect(Page.where(category: sports).first.active_sorting_value).to eq Page.active_sorting_step
        expect(Page.where(category: sports).last.active_sorting_value).to eq 5 * Page.active_sorting_step
      end
    end

    context 'default_scope' do
      before do
        10.times { Page.create!(title: 'test local page', category: local) }
      end

      it 'adds ORDER to SQL queries' do
        expect(Page.all.to_sql).to include 'ORDER'
      end

      it 'orders items by sortable field' do
        expect(Page.first.active_sorting_value).to eq Page.active_sorting_step
        expect(Page.all.to_a.second.active_sorting_value).to eq 2 * Page.active_sorting_step
        expect(Page.last.active_sorting_value).to eq 10 * Page.active_sorting_step
      end
    end

    context 'hooks' do
      context 'before_create' do
        it { expect(item.active_sorting_value).not_to be_nil }

        it 'generates correct steppings' do
          items.each_with_index do |item, index|
            value = (index + 1) * item.class.active_sorting_step
            expect(item.active_sorting_value.to_s).to eq value.to_s
          end
        end
      end

      context 'before_update' do
        before do
          item.save!
        end
        it 'does not change sorting field' do
          expect(item.active_sorting_value).not_to be_nil
        end
      end
    end
  end

  context '.sort_list' do
    let(:new_list) { [1, 3, 5, 4, 6, 2, 7] }
    before do
      items # just create the items
      item.class.sort_list(new_list)
    end
    it { expect(Item.all.pluck(:id)).to eq new_list }
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

  context '#active_sorting_center_item' do
    it 'centers an item between two given positions' do
      expect(item.active_sorting_center_item(100, 200).active_sorting_value).to eq 150
      expect(item.active_sorting_center_item(100_000_000, 100_000_002).active_sorting_value).to eq 100_000_001
      expect(item.active_sorting_center_item(2_000_000_000, 2_000_000_002).active_sorting_value).to eq 2_000_000_001
    end
  end
end
