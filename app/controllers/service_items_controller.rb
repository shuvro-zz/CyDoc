# -*- encoding : utf-8 -*-
class ServiceItemsController < AuthorizedController
  # GET /service_records/select
  def select
    query = params[:query]
    query ||= params[:search][:query] if params[:search]

    @tariff_items = TariffItem.valid.order('duration_from DESC').clever_find(query)
    @tariff_item = TariffItem.find(params[:tariff_item_id])

    # Show selection list only if more than one hit
    if @tariff_items.pluck(:code).uniq.size == 1
      params[:tariff_item_id] = @tariff_item.id
      params[:select_item_id] = @tariff_items.first.id
      create
      return
    end
  end

  # GET /service_records/new
  def new
    @tariff_item = TariffItem.find(params[:tariff_item_id])
    @service_item = @tariff_item.service_items.build

    # Defaults
    @service_item.quantity = 1
  end

  # POST /service_items
  def create
    @tariff_item = TariffItem.find(params[:tariff_item_id])

    tariff_item = TariffItem.find(params[:select_item_id])

    # Handle TariffItemGroups
    if tariff_item.is_a? TariffItemGroup
      @tariff_item.service_items << tariff_item.service_items
    else
      service_item = @tariff_item.service_items.build(params[:service_item])
      service_item.code = tariff_item.code
      service_item.quantity = 1

      service_item.save!
    end
  end
end
