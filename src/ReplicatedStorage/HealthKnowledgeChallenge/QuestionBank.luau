--!strict

export type Question = {
	id: string,
	category: string,
	prompt: string,
	options: { string },
	correctIndex: number,
	explanation: string,
}

local questions: { Question } = {
	{
		id = "immune_01",
		category = "Immune System",
		prompt = "What is one main role of white blood cells?",
		options = {
			"Carrying oxygen around the body",
			"Helping defend the body against harmful microbes",
			"Digesting all food in the stomach",
			"Producing bones",
		},
		correctIndex = 2,
		explanation = "White blood cells are important parts of the immune system and help identify and respond to harmful microbes.",
	},
	{
		id = "immune_02",
		category = "Immune System",
		prompt = "What do immune memory cells help the body do?",
		options = {
			"Forget previous infections",
			"Respond faster when a familiar threat appears again",
			"Stop the heart from beating quickly",
			"Replace all red blood cells",
		},
		correctIndex = 2,
		explanation = "Memory cells can recognize a previously encountered threat and support a faster immune response.",
	},
	{
		id = "immune_03",
		category = "Immune System",
		prompt = "Which statement best describes inflammation?",
		options = {
			"It is always a disease",
			"It is part of the body's response to injury or infection",
			"It permanently switches off immunity",
			"It only happens after exercise",
		},
		correctIndex = 2,
		explanation = "Inflammation is a protective response that can help the body deal with injury or infection, although excessive inflammation can be harmful.",
	},
	{
		id = "immune_04",
		category = "Immune System",
		prompt = "Which body system works closely with the immune system to move immune cells?",
		options = {
			"The circulatory system",
			"The calendar system",
			"The keyboard system",
			"The traffic-light system",
		},
		correctIndex = 1,
		explanation = "Blood and lymphatic circulation help transport immune cells and signals throughout the body.",
	},
	{
		id = "immune_05",
		category = "Immune System",
		prompt = "Which statement about fever is most accurate?",
		options = {
			"Fever is always harmless",
			"Fever can be part of the body's response to infection",
			"Fever means antibiotics are always required",
			"Fever only occurs in winter",
		},
		correctIndex = 2,
		explanation = "Fever can be part of an immune response. High, persistent, or concerning fever should be assessed by a qualified health professional.",
	},
	{
		id = "vaccine_01",
		category = "Vaccines",
		prompt = "What is the main purpose of a vaccine?",
		options = {
			"To train the immune system to recognize a specific threat",
			"To replace sleep",
			"To cure every illness immediately",
			"To remove the need for hygiene",
		},
		correctIndex = 1,
		explanation = "Vaccines expose the immune system to safe information about a threat so it can prepare a protective response.",
	},
	{
		id = "vaccine_02",
		category = "Vaccines",
		prompt = "Why can high vaccination coverage help protect vulnerable people?",
		options = {
			"It can reduce opportunities for some infections to spread",
			"It guarantees that nobody can ever become ill",
			"It removes all microbes from the environment",
			"It replaces medical care",
		},
		correctIndex = 1,
		explanation = "When fewer people can transmit an infection, some vulnerable people may receive indirect protection.",
	},
	{
		id = "vaccine_03",
		category = "Vaccines",
		prompt = "Which is the best source for personal vaccination advice?",
		options = {
			"An anonymous social-media comment",
			"A qualified healthcare professional or official public-health source",
			"A random game chat",
			"An unverified advertisement",
		},
		correctIndex = 2,
		explanation = "Personal health decisions should be discussed with qualified professionals and supported by reliable public-health information.",
	},
	{
		id = "vaccine_04",
		category = "Vaccines",
		prompt = "What may happen after some vaccinations?",
		options = {
			"Mild temporary effects such as soreness can occur",
			"Every person develops the disease",
			"The immune system permanently stops working",
			"No biological response is possible",
		},
		correctIndex = 1,
		explanation = "Some people experience temporary effects such as soreness or fatigue as the immune system responds.",
	},
	{
		id = "vaccine_05",
		category = "Vaccines",
		prompt = "Why are vaccines evaluated before and after approval?",
		options = {
			"To study safety and effectiveness",
			"To make medical information secret",
			"To eliminate the need for research",
			"To prevent doctors from reporting concerns",
		},
		correctIndex = 1,
		explanation = "Clinical evaluation and ongoing monitoring provide evidence about vaccine safety and effectiveness.",
	},
	{
		id = "habit_01",
		category = "Healthy Habits",
		prompt = "Why is washing hands with soap useful?",
		options = {
			"It can remove many microbes and reduce transmission",
			"It makes vaccines unnecessary",
			"It guarantees that illness is impossible",
			"It only changes the smell of the hands",
		},
		correctIndex = 1,
		explanation = "Proper handwashing can remove many microbes and reduce the chance of spreading infections.",
	},
	{
		id = "habit_02",
		category = "Healthy Habits",
		prompt = "Which habit generally supports overall health?",
		options = {
			"Regular sleep, balanced nutrition, and physical activity",
			"Avoiding all water",
			"Using antibiotics for every cold",
			"Ignoring persistent symptoms",
		},
		correctIndex = 1,
		explanation = "Sleep, balanced nutrition, and physical activity support overall wellbeing. They do not replace professional medical care.",
	},
	{
		id = "habit_03",
		category = "Healthy Habits",
		prompt = "Antibiotics are designed primarily to treat which type of infection?",
		options = {
			"Bacterial infections",
			"Every viral infection",
			"All allergies",
			"Muscle tiredness",
		},
		correctIndex = 1,
		explanation = "Antibiotics target bacteria and do not treat viral infections such as ordinary colds. They should be used as prescribed.",
	},
	{
		id = "habit_04",
		category = "Healthy Habits",
		prompt = "What should you do with important health information found online?",
		options = {
			"Check the source and compare it with reliable medical guidance",
			"Share it immediately without reading it",
			"Assume the most dramatic claim is correct",
			"Use the number of likes as scientific proof",
		},
		correctIndex = 1,
		explanation = "Reliable health communication depends on credible sources, evidence, and appropriate professional guidance.",
	},
	{
		id = "habit_05",
		category = "Healthy Habits",
		prompt = "Which action can reduce respiratory-droplet spread when someone is coughing?",
		options = {
			"Covering coughs appropriately and following current health guidance",
			"Sharing drinking cups",
			"Standing closer to everyone",
			"Ignoring ventilation completely",
		},
		correctIndex = 1,
		explanation = "Appropriate cough etiquette, ventilation, and context-specific public-health guidance can help reduce transmission.",
	},
}

local byId: { [string]: Question } = {}
local byCategory: { [string]: { Question } } = {}

for _, question in questions do
	byId[question.id] = question
	byCategory[question.category] = byCategory[question.category] or {}
	table.insert(byCategory[question.category], question)
end

local QuestionBank = {}

function QuestionBank.getById(id: string): Question?
	return byId[id]
end

function QuestionBank.getByCategory(category: string): { Question }
	return byCategory[category] or {}
end

function QuestionBank.getCategories(): { string }
	local categories = {}
	for category in byCategory do
		table.insert(categories, category)
	end
	table.sort(categories)
	return categories
end

return QuestionBank
